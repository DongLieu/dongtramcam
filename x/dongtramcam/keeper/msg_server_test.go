package keeper_test

import (
	"context"
	"testing"

	keepertest "dongtramcam/testutil/keeper"
	"dongtramcam/x/dongtramcam/keeper"
	"dongtramcam/x/dongtramcam/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func setupMsgServer(t testing.TB) (types.MsgServer, context.Context) {
	k, ctx := keepertest.DongtramcamKeeper(t)
	return keeper.NewMsgServerImpl(*k), sdk.WrapSDKContext(ctx)
}
